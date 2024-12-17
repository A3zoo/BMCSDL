from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, String
import uuid
from sqlalchemy import text
from database import mgr_Session as Session
from pydantic import BaseModel, ConfigDict
from typing import Optional

## Làm theeo encode oracle

class UserAccount(Base):
    __tablename__: str = 'USERACCOUNT'

    Email: Mapped[str] = mapped_column(String(25), nullable=True, name='EMAIL')
    CCCD: Mapped[str] = mapped_column(String(20), primary_key=True, name='CCCD')
    Sdt: Mapped[str] = mapped_column(String(25), nullable=True, name='SDT')
    Password: Mapped[str] = mapped_column(String(100), nullable=True, name='PASSWORD')
    UserType: Mapped[str] = mapped_column(String(15), nullable=True, name='USERTYPE')

class UserAccountModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    Email: Optional[str] = None  # Email có thể rỗng
    Cccd: Optional[str] = None  # CCCD có thể rỗng
    Sdt: Optional[str] = None  # Số điện thoại có thể rỗng
    Password: Optional[str] = None  # Mật khẩu có thể rỗng
    UserType: Optional[str] = None  # Loại người dùng có thể rỗng

def get_account_by_cccd_pw(cccd, password):
    with Session() as session:
        result = session.execute(
                text('SELECT db_manager.CheckLoginStatus(:p_CCCD,:p_password) AS result  FROM dual'),
                {"p_CCCD": cccd, "p_password": password}
            ).fetchall()
        if result[0][0] == 'TRUE':
            user = session.query(UserAccount).filter(UserAccount.CCCD == cccd).first()
            
            if user:
                return UserAccountModel.validate(user)
            else:
                return None
        return None
