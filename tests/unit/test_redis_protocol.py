from dredis.parser import Parser


def test_parse_simple_string():
    def read(n):
        return b"+PING\r\n"

    p = Parser(read)
    assert list(p.get_instructions()) == [[b'PING']]


def test_simple_array():
    def read(n):
        return b"*1\r\n$4\r\nPING\r\n"

    p = Parser(read)
    assert list(p.get_instructions()) == [[b'PING']]


def test_bulk_string_inside_array():
    def read(n):
        return b"\
*5\r\n\
$4\r\n\
EVAL\r\n\
$69\r\n\
redis.call('set', KEYS[1], KEYS[2])\n\
return redis.call('get', KEYS[1])\r\n\
$1\r\n\
2\r\n\
$7\r\n\
testkey\r\n\
$9\r\n\
testvalue\r\n"

    p = Parser(read)
    assert list(p.get_instructions()) == [[
        b'EVAL',
        b'''redis.call('set', KEYS[1], KEYS[2])\nreturn redis.call('get', KEYS[1])''',
        b'2',
        b'testkey',
        b'testvalue'
    ]]


def test_multiple_arrays():
    def read(n):
        return b"*1\r\n$4\r\nPING\r\n*1\r\n$4\r\nPING\r\n"

    p = Parser(read)
    assert list(p.get_instructions()) == [[b'PING'], [b'PING']]


def test_parser_should_request_more_data_if_needed():
    responses = [
        b"*1\r\n$4\r\n",
        b"PING\r\n"
    ]

    def read(bufsize):
        return responses.pop(0)

    p = Parser(read)
    assert list(p.get_instructions()) == [[b'PING']]
