import pandas as pd

from . import splitdate

def test_splitdate():
    out = splitdate.splitdate(begin, date)
    
    d = {'Date': [2019-12-12]}
    begin = pd.DataFrame(data=d)
    e = {'Date': [2019-12-12], 'year': [2019], 'month': [12], 'day': [12]}
    expected = 
    assert expected == out