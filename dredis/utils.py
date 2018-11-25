def to_float(s):
    # Redis uses `strtod` which converts empty string to 0
    if s == b'':
        return 0
    else:
        return float(s)


def to_str(s):
    if isinstance(s, bytes):
        return s.decode()
    return str(s)
