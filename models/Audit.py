from datetime import datetime
from typing import Optional
from sqlalchemy import Column, Integer, String, TIMESTAMP, desc
from sqlalchemy.ext.declarative import declarative_base
from pydantic import BaseModel, ConfigDict
from .base import Base
from database import get_user_session
class PassportAuditLog(Base):
    __tablename__ = 'PASSPORT_AUDIT_LOG'

    audit_id = Column('audit_id', Integer, primary_key=True, autoincrement=True)
    username = Column('username', String(50), nullable=False)
    role = Column('role', String(10), nullable=True)
    operation = Column('operation', String(10), nullable=False)
    old_data = Column('old_data', String(50), nullable=True)
    new_data = Column('new_data', String(50), nullable=True)
    change_date = Column('change_date', TIMESTAMP, nullable=False)
    description = Column('description', String(1000), nullable=True)
    
class PassportAuditLogModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    audit_id: Optional[int]
    username: Optional[str]
    role: Optional[str]
    operation: Optional[str]
    old_data: Optional[str]
    new_data: Optional[str]
    change_date: Optional[datetime]
    description: Optional[str]


def get_all_audit():
    Session = get_user_session()  # Hàm này trả về một session kết nối tới database
    with Session() as session_db:
        # Truy vấn tất cả các bản ghi trong bảng PassportAuditLog
        audits = session_db.query(PassportAuditLog).order_by(desc(PassportAuditLog.change_date)).all()
        
        # Nếu có dữ liệu, chuyển đổi từng bản ghi thành PassportAuditLogModel
        if audits:
            return [PassportAuditLogModel.model_validate(audit) for audit in audits]
        else:
            return []
