Events = {}

Events.register = function(eventName, callback)
    if(Events[eventName] == nil) then
        Events[eventName] = {};
    end
    local event = Events[eventName];
    event[#event+1] = callback;
end

Events.unregister = function(eventName, callback)
    local event = Events[eventName];
    if(event == nil) then return end;
    for i=1,#event do
        if(event[i] == callback) then
            event[i] = nil;
        end
    end
    condenseArray(event);
end

Events.clearEvent = function(eventName)
    if(Event[eventName] == nil) then return end;
    Event[eventName] = {};
end

Events.broadcast = function(eventName, params)
    local event = Events[eventName];
    if(event == nil) then return end;
    for i=1,#event do
        event[i](params);
    end
end