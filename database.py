from typing import Literal
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from flask import session
from env import env_data
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

def get_user_session():
        return get_session(session['cccd'], session['password'])
mgr_Session = get_session(env_data.login_user, env_data.login_user_pass)
