from typing import Literal
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from flask import session

def get_session(username, password, host = 'localhost', port = '1521', service= 'ORCLPDB'):
    engine = create_engine(
        f'oracle+oracledb://:@',
            thick_mode=False,
            connect_args={
                "user": username,
                "password": password,
                "host": host,
                "port": port,
                "service_name": service
        })

    # Tạo một session
    Session = sessionmaker(bind=engine)
    return Session
mgr_Session = get_session('SEC_MGR', 'quangduy')
user_Session = get_session(session['cccd'], session['password'])