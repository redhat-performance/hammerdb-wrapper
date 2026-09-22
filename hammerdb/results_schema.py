import pydantic
import datetime

class Hammerdb_Results(pydantic.BaseModel):
    connection: int = pydantic.Field(gt=0)
    TPM: int = pydantic.Field(gt=0)
    Start_Date: datetime.datetime
    End_Date: datetime.datetime
