"""Order search from the ticket shop API, in an unsafe and a safe version."""

import sys

import psycopg


def find_orders_unsafe(cur, email):
    # The input becomes part of the SQL text.
    cur.execute(f"SELECT id, email, total FROM orders WHERE email = '{email}'")
    return cur.fetchall()


def find_orders_safe(cur, email):
    # The input travels separately from the SQL and is never parsed as SQL.
    cur.execute('SELECT id, email, total FROM orders WHERE email = %s', (email,))
    return cur.fetchall()


mode, email = sys.argv[1], sys.argv[2]
find = find_orders_safe if mode == 'safe' else find_orders_unsafe
with psycopg.connect('host=127.0.0.1 dbname=shop user=shop_api', autocommit=True) as conn:
    try:
        for row in find(conn.cursor(), email):
            print(row)
    except psycopg.Error as e:
        print(f'{type(e).__name__}: {e}')
