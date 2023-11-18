from pathlib import Path

import pyopenjtalk


def _print_results(njd_features, labels):
    for f in njd_features:
        s, p = f["string"], f["pron"]
        print(s, p)

    for label in labels:
        print(label)


def test_hello():
    njd_features = pyopenjtalk.run_frontend("こんにちは")
    labels = pyopenjtalk.make_label(njd_features)
    _print_results(njd_features, labels)


def test_njd_features():
    njd_features = pyopenjtalk.run_frontend("こんにちは")
    expected_feature = [
        {
            "string": "こんにちは",
            "pos": "感動詞",
            "pos_group1": "*",
            "pos_group2": "*",
            "pos_group3": "*",
            "ctype": "*",
            "cform": "*",
            "orig": "こんにちは",
            "read": "コンニチハ",
            "pron": "コンニチワ",
            "acc": 0,
            "mora_size": 5,
            "chain_rule": "-1",
            "chain_flag": -1,
        }
    ]
    assert njd_features == expected_feature


def test_fullcontext():
    features = pyopenjtalk.run_frontend("こんにちは")
    labels = pyopenjtalk.make_label(features)
    labels2 = pyopenjtalk.extract_fullcontext("こんにちは")
    for a, b in zip(labels, labels2):
        assert a == b


def test_jtalk():
    for text in [
        "今日も良い天気ですね",
        "こんにちは。",
        "どんまい！",
        "パソコンのとりあえず知っておきたい使い方",
    ]:
        njd_features = pyopenjtalk.run_frontend(text)
        labels = pyopenjtalk.make_label(njd_features)
        _print_results(njd_features, labels)

        surface = "".join(map(lambda f: f["string"], njd_features))
        assert surface == text


def test_g2p_kana():
    for text, pron in [
        ("今日もこんにちは", "キョーモコンニチワ"),
        ("いやあん", "イヤーン"),
        ("パソコンのとりあえず知っておきたい使い方", "パソコンノトリアエズシッテオキタイツカイカタ"),
    ]:
        p = pyopenjtalk.g2p(text, kana=True)
        assert p == pron


def test_g2p_phone():
    for text, pron in [
        ("こんにちは", "k o N n i ch i w a"),
        ("ななみんです", "n a n a m i N d e s U"),
        ("ハローユーチューブ", "h a r o o y u u ch u u b u"),
    ]:
        p = pyopenjtalk.g2p(text, kana=False)
        assert p == pron


def test_userdic():
    for text, expected in [
        ("nnmn", "n a n a m i N"),
        ("GNU", "g u n u u"),
    ]:
        p = pyopenjtalk.g2p(text)
        assert p != expected

    user_csv = str(Path(__file__).parent / "test_data" / "user.csv")
    user_dic = str(Path(__file__).parent / "test_data" / "user.dic")

    with open(user_csv, "w", encoding="utf-8") as f:
        f.write("ｎｎｍｎ,,,1,名詞,一般,*,*,*,*,ｎｎｍｎ,ナナミン,ナナミン,1/4,*\n")
        f.write("ＧＮＵ,,,1,名詞,一般,*,*,*,*,ＧＮＵ,グヌー,グヌー,2/3,*\n")

    pyopenjtalk.mecab_dict_index(f.name, user_dic)
    pyopenjtalk.update_global_jtalk_with_user_dict(user_dic)

    for text, expected in [
        ("nnmn", "n a n a m i N"),
        ("GNU", "g u n u u"),
    ]:
        p = pyopenjtalk.g2p(text)
        assert p == expected
