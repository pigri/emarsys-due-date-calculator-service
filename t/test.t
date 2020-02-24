# vi:filetype=

use lib 'lib';
use Test::Nginx::Socket;

plan tests => 2 * blocks();

run_tests();

__DATA__

=== TEST 1: 8 hours working day
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-07%2009%3A00%3A00&turnaround=8
--- response_body
{"data":{"duedate":"2020-02-07 17:00:00"}}

=== TEST 2: 16 hours working day
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-05%2009%3A00%3A00&turnaround=16
--- response_body
{"data":{"duedate":"2020-02-06 17:00:00"}}


=== TEST 3: 16 hours working day + weekend
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-07%2009%3A00%3A00&turnaround=16
--- response_body
{"data":{"duedate":"2020-02-10 17:00:00"}}

=== TEST 4: turnaround is not whole number
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-07%2009%3A00%3A00&turnaround=16.82
--- response_body
{"data":{"duedate":"2020-02-11 09:49:12"}}

=== TEST 5: Out of working hour
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }

--- request
    GET /t?issue_start=2020-02-07%2008%3A00%3A00&turnaround=16.82
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"Out of working hour"}}

=== TEST 6: Out of working day
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-09%2008%3A00%3A00&turnaround=16.82
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"Out of working day"}}

=== TEST 7: Invalid date format
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020!!!!02-09%2008%3A00%3A00&turnaround=16.82
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"DATE format is invalid"}}

=== TEST 8: Turnaround is not number
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-07%2009%3A00%3A00&turnaround=example
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"TURNAROUND is not a number"}}

=== TEST 8: Turnaround parameter is missing
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?issue_start=2020-02-07%2009%3A00%3A00
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"TURNAROUND parameter is missing"}}

=== TEST 9: Issue_start parameter is missing
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t?turnaround=example
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"ISSUE_START parameter is missing"}}

=== TEST 10: All parameter is missing
--- config
    location /t {
        charset utf-8;
        charset_types application/json;
        default_type application/json;
        content_by_lua_file ../../src/calc.lua;
    }
--- request
    GET /t
--- error_code: 400
--- response_body
{"error":{"status":400,"message":"Parameters are not found"}}
