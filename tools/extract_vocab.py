#!/usr/bin/env python3
"""
extract_vocab.py — 雅思词汇绿宝书 OCR 文本 → vocab.json

固定 OCR 文本对齐问题：每个英文词与其后方最近的中文释义配对，
而非分别按数量配对后再对齐索引。

用法:
  python3 extract_vocab.py --input tools/ocr_output.txt --output Sources/IELTSDictationCore/Resources/vocab.json
"""

import re, json, argparse

_KEEP_CHN = re.compile(r'[\u4e00-\u9fff…—，。、；：""''！？（）\-]')
_CHN_STARTER = r'[\u4e00-\u9fff…—，。、；：""''！？（）\-]'

POS_TAGS = r'|'.join([
    r'n\.', r'a\.', r'v\.', r'ad\.', r'prep\.', r'conj\.',
    r'int\.', r'vt\.', r'vi\.', r'num\.', r'art\.', r'pron\.',
    r'pl\.', r'aux\.', r'det\.', r'abbr\.'
])

def extract_chinese_only(text: str) -> str:
    return ''.join(_KEEP_CHN.findall(text))

def extract(input_path: str, output_path: str) -> dict:
    with open(input_path, encoding="utf-8") as f:
        text = f.read()

    # 按 "Word List N" 标题分割
    sections = re.split(r'(Word List \d+)', text)
    if len(sections) < 3:
        raise ValueError("未找到 Word List 标题")

    # 构建 list_id → content 映射
    list_map = {}
    for i in range(1, len(sections) - 1, 2):
        header = sections[i].strip()
        content = sections[i + 1]
        m = re.search(r'\d+', header)
        if m:
            lid = int(m.group())
            # 只保留 1-48 范围的实际词库（跳过目录页、词根预习等）
            if 1 <= lid <= 48:
                list_map.setdefault(lid, "")
                list_map[lid] += "\n" + content

    lists_out = []

    for lid in sorted(list_map.keys()):
        content = list_map[lid]
        lines = content.splitlines()

        # ===== 扫描行，为每个 bullet 词找到最近的下方中文释义 =====
        # 先构建 bullet_words 列表 [(index, word), ...]
        bullet_at = []  # [(line_idx, word)]
        for li, l in enumerate(lines):
            ls = l.strip()
            m = re.match(r'^[□口]\s*([A-Za-z][A-Za-z\'-]*)', ls)
            if m:
                w = m.group(1).lower().strip().rstrip("'\"")
                if 1 <= len(w) <= 25:
                    bullet_at.append((li, w))

        # 再构建 chinese_defs 列表 [(line_idx, pos, zh), ...]
        defs_at = []
        for li, l in enumerate(lines):
            ls = l.strip()
            m = re.match(rf'^({POS_TAGS})\s*({_CHN_STARTER}.*)', ls, re.I)
            if m:
                pos_tag = m.group(1).lower().rstrip('.')
                chn_text = m.group(2).strip()
                chn_only = extract_chinese_only(chn_text)
                if chn_only:
                    defs_at.append((li, pos_tag, chn_only))

        # 配对：对每个 bullet word，找其后最近的 definition
        words_out = []
        for b_idx, b_word in bullet_at:
            best_def = None
            best_dist = float('inf')
            for d_idx, d_pos, d_zh in defs_at:
                if d_idx > b_idx and d_idx - b_idx < best_dist:
                    best_def = (d_pos, d_zh)
                    best_dist = d_idx - b_idx
            if best_def:
                pos, full_zh = best_def
                full_zh = full_zh.strip('；，、 。')
                if full_zh:
                    words_out.append({
                        "en": b_word,
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
    p = argparse.ArgumentParser(description="从 OCR 文本提取雅思绿宝书词库")
    p.add_argument("--input", required=True, help="OCR 输出文本路径")
    p.add_argument("--output", required=True, help="vocab.json 输出路径")
    args = p.parse_args()

    result = extract(args.input, args.output)
    total = sum(len(lst["words"]) for lst in result["lists"])
    print(json.dumps({"lists": len(result["lists"]), "words": total}))
