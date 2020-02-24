local date = os.date
local inputdate = tostring("2019-11-08 14:00:00")
local turnaround = tonumber(41) * 3600

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
    return true
  else
    return false
  end
end

local daystart = DateParsing(inputdate)
local year = date("%Y", daystart)
local month = date("%m", daystart)
local day = date("%d", daystart)
local nextday_step = 57600
next_day = os.time({day=day,month=month,year=year,hour=17,min=00,sec=00})
local working_step = 28800
remaining = turnaround - ( next_day - daystart )

if(remaining <= 0 ) then
  print(HumanDate(next_day))
else
  repeat
    next_day = next_day + nextday_step
    if(WeekendCheck(next_day) == true ) then
      next_day = next_day + (2*86400)
    end
    if (remaining > working_step) then
      remaining = remaining - working_step
    else
      next_day = next_day + nextday_step + remaining
      if(WeekendCheck(next_day) == true ) then
        next_day = next_day + (2*86400)
        remaining = 0
      end
      remaining = 0
    end
    next_day = next_day + working_step
  until (remaining <= 0)
    print(HumanDate(next_day))
end
