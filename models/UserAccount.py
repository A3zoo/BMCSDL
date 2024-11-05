from .base import Base
from sqlalchemy.orm import mapped_column, Mapped
from sqlalchemy import UUID, String
import uuid
from database import session

## Làm theeo encode oracle

class UserAccount(Base):
    __tablename__: str = 'UserAccount'
    __table_args__ = {'extend_existing': True, 'quote': False}
    Id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, name='ID'
    )
    Email: Mapped[str] = mapped_column(String(100), nullable=True, name='EMAIL')
    Sdt: Mapped[str] = mapped_column(String(100), nullable=True, name='SDT')
    Password: Mapped[str] = mapped_column(String(15), nullable=True, name='PASSWORD')
    UserType: Mapped[str] = mapped_column(String(15), nullable=True, name='USERTYPE')
