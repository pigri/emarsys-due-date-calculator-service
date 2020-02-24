local date = os.date
local inputdate = tostring("2019-11-08 11:00:00")
local turnaround = tonumber(39.41) * 3600

function DateParsing(date)
  local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
  local year, month, day, hour, min, sec = date:match(pattern)
  return os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})
end

function HumanDate(timestamp)
  return date("%Y-%m-%d %H:%M:%S", timestamp)
end

function WeekendCheck(timestamp)
  local weekday = date("%w", timestamp)
  if (weekday == "6") then
    return 2*86400
  else
    return 0
  end
end

local daystart = DateParsing(inputdate)
local year = date("%Y", daystart)
local month = date("%m", daystart)
local day = date("%d", daystart)
local nextday_step = 57600
Nextday = os.time({day=day,month=month,year=year,hour=17,min=00,sec=00})
local working_step = 28800
Remaining = turnaround - ( Nextday - daystart )

if(Remaining <= 0 ) then
  print(HumanDate(Nextday))
else
  repeat
    Nextday = Nextday + nextday_step
    Nextday = Nextday + WeekendCheck(Nextday)
    if (Remaining > working_step) then
      Remaining = Remaining - working_step
    else
      Nextday = Nextday + nextday_step + Remaining
      Nextday = Nextday + WeekendCheck(Nextday)
      Remaining = 0
    end
    Nextday = Nextday + working_step
  until (Remaining <= 0)
    print(HumanDate(Nextday))
end
