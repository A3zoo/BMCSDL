from typing import Literal
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

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
    session = Session()
    return session

session = get_session('SEC_MGR', 'quangduy')

class User():
    """Class Definition to handle Flask login for user"""
    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.id = id
    
    @staticmethod 
    def is_authenticated() -> Literal[True]:
        return True
    
    @staticmethod
    def is_active():
        return True
    
    @staticmethod
    def is_anonymous():
        return False
    
    def get_id(self):
        return self.id
