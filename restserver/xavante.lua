
local restserver_xavante = {}

local xavante = require("xavante")
local wsapi = require("wsapi.xavante")

local function start(self, callback, timeout)
   local rules = {}
   for path, _ in pairs(self.config.paths) do
      -- TODO support placeholders in paths
      rules[#rules + 1] = {
         match = path,
         with = wsapi.makeHandler(self.wsapi_handler)
      }
   end

   -- HACK: There's no public API to change the server identification
   xavante._VERSION = "SGA"
   xavante.HTTP {
      server = {host = self.config.host or "*", port = self.config.port or 8080 },
      defaultHost = {
         rules = rules
      }
   }
   
   local ok, err = pcall(xavante.start, function()
      io.stdout:flush()
      io.stderr:flush()
      if callback then
        callback()
      end
      return self.should_terminate
   end, timeout)
   
   if not ok then
      return nil, err
   end
   return true
end

local function shutdown(self)
   self.should_terminate = true
end

function restserver_xavante.extend(self)
   self.start = start
   self.shutdown = shutdown
end

return restserver_xavante

