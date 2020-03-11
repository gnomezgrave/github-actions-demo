import pytest

from lambda_func import my_function


class TestMyAwesomeLambda:

    def test_my_func(self):
        out = my_function(10, 20)
        assert out == 30
