#!/usr/bin/env python3
"""
extract_vocab.py — 雅思词汇绿宝书 OCR 文本 → vocab.json

从 OCR 输出的纯文本中提取词条（英文单词 + 中文释义 + 词性），
输出为应用随包加载的 vocab.json。

策略: 每条词条只保留【主释义】（以词性标签开头的那行），
       跳过所有 "记 / 搭 / 例 / 同 / 派 / 圆" 等附属内容。

用法:
  python3 extract_vocab.py --input tools/ocr_output.txt --output Sources/IELTSDictationCore/Resources/vocab.json
"""

import re, json, argparse

# 保留中文 + 中文标点，去掉所有英文 / 数字 / 拉丁字符
_KEEP_CHN = re.compile(r'[\u4e00-\u9fff…—，。、；：""''！？（）\-]')
_CHN_STARTER = r'[\u4e00-\u9fff…—，。、；：""''！？（）\-]'


def extract_chinese_only(text: str) -> str:
    """从字符串中提取中文字符和中文标点。"""
    return ''.join(_KEEP_CHN.findall(text))


def extract(input_path: str, output_path: str) -> dict:
    with open(input_path, encoding="utf-8") as f:
        text = f.read()

    # 按 "Word List N" 标题分割
    sections = re.split(r'(Word List \d+)', text)
    if len(sections) < 3:
        raise ValueError("未找到 Word List 标题，OCR 文本格式不符")

    # 构建 {list_id: content_text} 映射（同一 list 可能跨多页）
    list_map = {}
    for i in range(1, len(sections) - 1, 2):
        header = sections[i].strip()
        content = sections[i + 1]
        m = re.search(r'\d+', header)
        if m:
            lid = int(m.group())
            list_map.setdefault(lid, "")
            list_map[lid] += "\n" + content

    # 词性标签（OCR 可能出现的常见缩写）
    POS_TAGS = r'|'.join([
        r'n\.', r'a\.', r'v\.', r'ad\.', r'prep\.', r'conj\.',
        r'int\.', r'vt\.', r'vi\.', r'num\.', r'art\.', r'pron\.',
        r'pl\.', r'aux\.', r'det\.', r'abbr\.'
    ])

    lists_out = []

    for lid in sorted(list_map.keys()):
        content = list_map[lid]
        lines = content.splitlines()

        # 步骤 A: 收集 "口" / "□" 标记的英文词
        bullet_words = []
        for l in lines:
            ls = l.strip()
            m = re.match(r'^[□口]\s*([A-Za-z][A-Za-z\'-]*)', ls)
            if m:
                w = m.group(1).lower().strip().rstrip("'\"")
                if 1 <= len(w) <= 25:
                    bullet_words.append(w)

        # 步骤 B: 收集中文主释义（仅首行，跳过记/搭/例/同/派/圆等附属）
        chinese_main = []
        current_pos = None
        for l in lines:
            ls = l.strip()
            pos_m = re.match(rf'^({POS_TAGS})\s*({_CHN_STARTER}.*)', ls, re.I)
            if pos_m:
                pos_tag = pos_m.group(1).lower().rstrip('.')
                chn_text = pos_m.group(2).strip()
                # 截取中文部分
                chn_only = extract_chinese_only(chn_text)
                chinese_main.append((pos_tag, chn_only))
                current_pos = pos_tag
            # 不再累积续行 — 跳过记/搭/例/同/派/圆 等附属内容

        # 步骤 C: 按顺序匹配英文词和中文主释义
        words_out = []
        min_len = min(len(bullet_words), len(chinese_main))
        for idx in range(min_len):
            word_en = bullet_words[idx]
            pos, full_zh = chinese_main[idx]
            # 清理：去掉首尾标点
            full_zh = full_zh.strip('；，、 。')
            if not full_zh:
                continue

            words_out.append({
                "en": word_en,
                "zh": full_zh[:80],
                "pos": pos + "." if not pos.endswith(".") else pos
            })

        if words_out:
            lists_out.append({"id": lid, "words": words_out})

    result = {
        "version": 1,
        "source": "雅思词汇绿宝书(1).pdf (via OCR + extract_vocab.py)",
        "lists": lists_out
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="从 OCR 文本提取雅思绿宝书词库")
    parser.add_argument("--input", required=True, help="OCR 输出文本路径")
    parser.add_argument("--output", required=True, help="vocab.json 输出路径")
    args = parser.parse_args()

    result = extract(args.input, args.output)
    total = sum(len(lst["words"]) for lst in result["lists"])
    print(json.dumps({"lists": len(result["lists"]), "words": total}))
