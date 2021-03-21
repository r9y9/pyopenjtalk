import pyopenjtalk


def _print_results(njd_results, labels):
    for n in njd_results:
        row = n.split(",")
        s, p = row[0], row[9]
        print(s, p)

    for label in labels:
        print(label)


def test_hello():
    njd_results, labels = pyopenjtalk.run_frontend("こんにちは")
    _print_results(njd_results, labels)


def test_fullcontext():
    _, labels = pyopenjtalk.run_frontend("こんにちは")
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
        njd_results, labels = pyopenjtalk.run_frontend(text)
        _print_results(njd_results, labels)

        surface = "".join(map(lambda s: s.split(",")[0], njd_results))
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
