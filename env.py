from dotenv import load_dotenv
import os

# Load variables from .env file
load_dotenv()

class EnvData:
    def __init__(self):
        self.login_user = os.getenv("LOGIN_USER")
        self.login_user_pass = os.getenv("LOGIN_USER_PASS")
        self.base_schema = os.getenv("BASE_SCHEMA")

    def __repr__(self):
        return (f"EnvData(login_user='{self.login_user}', "
                f"login_user_pass='{self.login_user_pass}', "
                f"base_schema='{self.base_schema}')")
    
env_data = EnvData()

