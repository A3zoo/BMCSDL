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
    __tablename__: str = 'UserAccount'
    __table_args__ = {'extend_existing': True, 'quote': False}
    Id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, name='ID'
    )
    Email: Mapped[str] = mapped_column(String(25), nullable=True, name='EMAIL')
    Cccd: Mapped[str] = mapped_column(String(20), nullable=True, name='CCCD')
    Sdt: Mapped[str] = mapped_column(String(25), nullable=True, name='SDT')
    Password: Mapped[str] = mapped_column(String(100), nullable=True, name='PASSWORD')
    UserType: Mapped[str] = mapped_column(String(15), nullable=True, name='USERTYPE')

class UserAccountModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    Id: UUID
    Email: Optional[str] = None  # Email có thể rỗng
    Cccd: Optional[str] = None  # CCCD có thể rỗng
    Sdt: Optional[str] = None  # Số điện thoại có thể rỗng
    Password: Optional[str] = None  # Mật khẩu có thể rỗng
    UserType: Optional[str] = None  # Loại người dùng có thể rỗng

def get_account_by_cccd_pw(cccd, password):
    with Session() as session:
        result = session.execute(
                text('SELECT CheckLoginStatus(:p_CCCD,:p_password) AS result  FROM dual'),
                {"p_CCCD": cccd, "p_password": password}
            ).fetchall()
        if result[0][0] == 'True':
            user = session.query(UserAccount).filter(UserAccount.Cccd == cccd).first()
            
            if user:
                return user
            else:
                return None
        return None
