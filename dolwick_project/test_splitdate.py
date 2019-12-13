import pandas as pd

from . import splitdate

def tsd():
    '''
    This function tests splitdate.splitdate. There are no arguments.
    '''
    d = {'Date': ['2019-12-12']}
    begin = pd.DataFrame(data=d)
    e = {'Date': ['2019-12-12'], 'year': ['2019'], 'month': ['12'], 'day': ['12']}
    expected = pd.DataFrame(data=e)
    out = splitdate.splitdate(begin, begin['Date'])
    pd.testing.assert_frame_equal(out, expected)