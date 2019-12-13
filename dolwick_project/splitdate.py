def splitdate(d, y):
    ds = y.str.split(pat = "-", expand = True)
    dsd = pd.concat([d, ds], axis=1, sort=False)
    ymd = dsd.rename(columns={0: "year", 1: "month", 2: "day"})
    return ymd

'''
The splitdate function allows me to split a column of dates within a pandas dataframe into three columns -- year, month, and day -- and to immediately concatenate those columns with the original dataframe and name them accordingly. Pandas must be installed to run this function.

d = Pandas dataframe
y = column of dates in yyyy-mm-dd format within d
'''
