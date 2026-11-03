"""パッケージが読み込めることを確かめる（最初のテストができたら消してよい）。"""

import package_name


def test_import_package_has_docstring() -> None:
    """パッケージを読み込むと docstring がある。"""
    assert package_name.__doc__
