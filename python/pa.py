#!/usr/bin/env python3
"""
Cipher text with basic translation.
"""
from argparse import ArgumentParser


MAX_ALLOWED = 126
UPPERCASE = 65
LOWERCASE = 97
ALPHABET_LENGTH = 26


def cipher(text: str, shift: int = 0, reverse: bool = False) -> str:
    """
    Cipher text.

    Shift applied after reversing.
    """
    result = ''

    for char in text:
        # 65 97 126
        code = ord(char)

        if code > MAX_ALLOWED:
            raise ValueError('Special characters not allowed: {}'.format(char))

        if code in range(UPPERCASE, UPPERCASE + ALPHABET_LENGTH):
            code -= UPPERCASE

            if reverse:
                code = ALPHABET_LENGTH - code

            code += shift
            code = code % ALPHABET_LENGTH
            code += UPPERCASE

        if code in range(LOWERCASE, LOWERCASE + ALPHABET_LENGTH):
            code -= LOWERCASE

            if reverse:
                code = ALPHABET_LENGTH - code

            code += shift
            code = code % ALPHABET_LENGTH
            code += LOWERCASE

        result += chr(code)

    return result


def main():
    parser = ArgumentParser()

    parser.add_argument(
        '-r',
        '--reverse',
        action='store_true',
        default=False,
        help='reverse alphabet'
    )

    parser.add_argument(
        '-s',
        '--shift',
        default=0,
        type=int,
        help='alphabet shift'
    )

    args = parser.parse_args()

    text = input('Type text to cipher: ')

    print(cipher(text, args.shift, args.reverse))


if __name__ == '__main__':
    main()

