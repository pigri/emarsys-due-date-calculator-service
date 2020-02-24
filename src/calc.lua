local ok,json = pcall(require, "cjson")
if not ok then
    error("cjson module required")
end

local date = os.date
local one_hour = 3600

local function humanDate(timestamp)
  return date("%Y-%m-%d %H:%M:%S", timestamp)
end

local function apiResponse(response)
    local status = 200
    ngx.say(json.encode({data = response}))
    return ngx.exit(status)
end

local function errorResponse(status, message)
    ngx.status = status
    ngx.say(json.encode({ error = { status = status, message = message } }))
    return ngx.exit(status)
end

local function parseDate(datetime)
  return datetime:match("(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)")
end

local function toTimeStamp(datetime)
  local year, month, day, hour, min, sec = parseDate(datetime)
  if year == nil then
    errorResponse(400, 'DATE format is invalid')
  end
  return os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})
end

local function weekendTime(timestamp)
  local weekday = os.date("%w", timestamp)
  if (weekday == "6") then
    return 48 * one_hour
  end
  return 0
end

local function getN(args)
    local counter = 0
    for key, val in pairs(args) do
        counter = counter + 1
    end
    return counter
end

local function argumentsValidator(args)
    if not args then
      errorResponse(400,'Parameters are not found')
    end

    if getN(args) == 0 then
      errorResponse(400,'Parameters are not found')
    end

    if getN(args) < 1 then
      errorResponse(400,'Parameters are not found')
    end

    if args['issue_start'] == nil then
      errorResponse(400, 'ISSUE_START parameter is missing')
    end

    if args['turnaround'] == nil then
      errorResponse(400, 'TURNAROUND parameter is missing')
    end
end

local function inputDateTimeValidator(datetime)
  local timestamp = toTimeStamp(datetime)
  local weekday = date("%w", timestamp)
  local hours = date("%H", timestamp)
  if weekday == "0" then
    errorResponse(400, 'Out of working day')
  elseif weekday == "6" then
    errorResponse(400, 'Out of working day')
  elseif tonumber(hours) < 9 then
    errorResponse(400, 'Out of working hour')
  elseif tonumber(hours) > 17 then
    errorResponse(400, 'Out of working hour')
  end
end

local function calculateDueDate(datetime, turnaround)
  local timestamp = toTimeStamp(datetime)
  local year = date("%Y", timestamp)
  local month = date("%m", timestamp)
  local day = date("%d", timestamp)
  local turnaround_seconds = turnaround * one_hour
  local workdaytime = 8 * one_hour
  local overnight = 16 * one_hour
  local duedate = os.time({day=day,month=month,year=year,hour=17,min=00,sec=00})
  local remaining = turnaround_seconds - ( duedate - timestamp )

  if(remaining == 0 ) then
      return duedate
  else
    repeat
      duedate = duedate + overnight
      duedate = duedate + weekendTime(duedate)
      if (remaining >= workdaytime) then
        remaining = remaining - workdaytime
      else
        duedate = duedate + remaining
        duedate = duedate + weekendTime(duedate)
        remaining = 0
        break
      end
      duedate = duedate + workdaytime
    until (remaining == 0)
      return duedate
  end
end

local args = ngx.req.get_uri_args()
argumentsValidator(args)

local datetime = tostring(ngx.unescape_uri(args['issue_start']))
local turnaround = tonumber(ngx.unescape_uri(args['turnaround']))
if turnaround == nil then
  errorResponse(400, 'TURNAROUND is not a number')
end

inputDateTimeValidator(datetime)

local duedate = calculateDueDate(datetime, turnaround)
apiResponse({duedate = humanDate(duedate)})
