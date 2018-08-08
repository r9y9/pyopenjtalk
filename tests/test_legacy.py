from pyopenjtalk.legacy import openjtalk
from nose.plugins.attrib import attr


@attr("local_only")
def test_legacy():
    prons, labels, params = openjtalk("こんにちは")
    for l in labels:
        print(l)
    assert "".join(prons) == "コンニチワ"
