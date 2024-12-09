from sqlalchemy import Column, String, DateTime, Text, create_engine, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from datetime import datetime
from .base import Base
from database import get_user_session

class AuditTrail(Base):
    __tablename__ = 'DBA_AUDIT_TRAIL' 
    entry_id = Column('ENTRYID', Integer, primary_key=True)
    username = Column('username', String, nullable=False)  # DBUSERNAME -> username
    action_name = Column('action_name',String, nullable=False)            
    obj_name = Column('obj_name', String, nullable=False) # OBJECT_NAME -> obj_name
    timestamp = Column('timestamp', DateTime, primary_key=True)  # EVENT_TIMESTAMP -> timestamp

class AuditTrailModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    username: Optional[str]
    action_name: Optional[str]
    obj_name: Optional[str]
    timestamp: Optional[datetime]
    entry_id: Optional[int]  # Changed from `String` to `str`


def get_audit_trails_for_passport():
    Session = get_user_session() 
    with Session() as session:
        results = (session.query(AuditTrail)
                          .filter_by(obj_name='PASSPORTDATA')
                          .order_by(AuditTrail.timestamp.desc())
                          .all())
        audit_trails = [AuditTrailModel.model_validate(record) for record in results]
        return audit_trails



                                      

