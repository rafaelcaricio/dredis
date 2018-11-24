def to_float(s):
    # Redis uses `strtod` which converts empty string to 0
    if s == '':
        return 0
    else:
        return float(s)

def to_str(s):
    if isinstance(s, bytes):
        return str(s, 'ISO-8859-1')
    return str(s)
