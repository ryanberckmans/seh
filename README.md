
- EventTarget is a mixin allowing any object to have events thrown at it
- Create an Event, add some targets - objects which mixin EventTarget - and dispatch the event.  Each Event is one-use-only
- Event has a list of types, e.g. :snow, :bad_weather, :sunshine; Types may be any object which defines equality ==
- Bind event callbacks to an EventTarget, e.g. my_target.bind(:snow) { "It's snowing!" }
- Bind event callbacks using a type boolean expression, my_target.bind( Seh::or :hurricane, Seh::and(:rain, :sunshine, Seh::not(:cold)) ) { "It's either a hurricane, or sunny and raining and not cold." }
- Disconnect binds, my_bind = my_target.bind ..; my_bind.disconnect
- EventTarget can add observers, or define a custom set of observers, which 'bubbles' events.

Staged Callbacks
- Events partition callbacks into stages; each event has the start and finish stages by default.  Other stages may be added, e.g. game damage event adds stages :add_bonus_damage and :apply_damage .  E.g. event.bind(:start) { "this event just started" };  event.bind(:apply_damage) { player.health -= event.damage }
- The start stage callbacks are executed first. The finish stage callbacks are executed last. Custom stages may declare dependencies on other stages and are executed in this order. E.g. the :apply_damage stage may depend on the :add_bonus_damage stage
- Seh Events bubble up through the set of observers before any staged callbacks execute. Each observer gets a chance to add callbacks to any event stage before the start stage callbacks begin executing.

Roadmap
- Efficiency


License


# seh: structured event handler

## Roadmap
* documentation
* unit tests (my bad)
* examples

## v0.1.0
seh API is fully implemented :)

## Contact
Please send (welcome) feedback and bug reports to ryan.berckmans@gmail.com.
