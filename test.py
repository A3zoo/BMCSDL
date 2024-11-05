from models.UserAccount import UserAccount
from database import get_session
from sqlalchemy import text


session = get_session('SEC_MGR', 'quangduy')

sdt = '012345683'
password = 'duy'
result = session.execute(
            text('SELECT CHECK_PASSWORD(:sdt,:password) AS result  FROM dual'),
            {"sdt": sdt, "password": password}
        )
# In ra các bản ghi
for user in result:
    print(user[0])

# Đóng session
session.close()
