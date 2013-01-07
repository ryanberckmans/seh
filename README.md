
# Seh

Structured event handler. Pure ruby event handling similar to w3c dom events. Check out `examples/epic_battle.rb`

# Why Seh?

Seh was developed as a dependency of my ruby game engine. I couldn't find another ruby event library with the features I wanted.

You might want to use Seh if:
* You need events/hooks/triggers/slots&signals
* You need a synchronous system, because an event must be fully resolved before things can continue
* An object/target/actor/thing might be affected by other things it doesn't know about
* Your objects have underlying hierarchical / graph / observer relationships
* You're hoping for *complex emergent behaviors*

You probably don't want to use Seh if:
* You need distributed or asynchronous events/hooks/triggers/slots&signals
* You're thinking "gee, this seems complicated, I really just need simple hooks"; Seh is probably over-engineering for you

# Features

Seh is driven by `Seh::Event` objects targeting objects of type `Seh::EventTarget`. Events are typed using `Seh::EventType` (which is mostly used implicitly).

In most event systems, including w3c dom events in a web browser, events are handled by child nodes before the event bubbles to ancestor nodes.  In Seh, each `EventTarget` which sees the `Event` may add callbacks to the event, before any callbacks are executed. After each `EventTarget` has been visited, the `Event` executes its callbacks. This allows an ancestor object to affect an outcome on a descendant.

Major Features
* `EventTarget` is a mixin allowing any object to be the target of `Event`
* Create an `Event`, add some targets - objects which mixin `EventTarget` - and dispatch the event.  Each `Event` is one-use-only
* `Event` has a list of types, e.g. :snow, :bad_weather, :sunshine; Types may be any object which defines equality ==
* Bind event callbacks to an EventTarget, e.g. `my_target.bind(:snow) { "It's snowing!" }`
* Bind event callbacks using a type boolean expression, e.g. `my_target.bind( Seh::or :hurricane, Seh::and(:rain, :sunshine, Seh::not(:cold)) ) { "It's either a hurricane, or sunny and raining and not cold." }`
* Disconnect callback binds, `my_bind = my_target.bind(:only_needed) { "for awhile" }; my_bind.disconnect`
* `EventTarget#observers` defaults to `[]`, and can be overridden to create an object graph. Each `EventTarget` recursively reachable by `EventTarget#observers` receives the event as if it was a top-level target.
* `Event` makes it easy for events to "inherit" from one another, so that you may develop a rich event hierarchy on your application side. Note that there's no real ruby class inheritance, e.g. in `examples/event/`, the Event::damage() method calls Event::hostile(), making each damage event a hostile event.
* Event stages provide fine-grained control over callbacks
* `Event` inherits from `OpenStruct` to easily define attributes on the event

# Understanding EventTargets, Stages, and Callbacks

See `Seh::Event#dispatch`.  When `#dispach` is called:
1. determine the full set of targets affected by this event
2. run callbacks on targets which match this event's types
3. run stage callbacks contained in this event; typically targets will append stage callbacks to this event using Event#bind, #start, #finish
4. Callback execution order: (1) start callbacks; (2) stage callbacks - in the order stages were added to the event; (3) finish callbacks

```ruby
target = Seh::EventTarget::Default.new # Default includes EventTarget
target.bind(:fireball) do |event| 
  puts "1"
  event.finish { puts "4" }
end

event = Seh::Event.new
event.type :fireball
event.target target
event.start { puts "2" }

event.add_stage :burn_enemy
event.bind(:burn_enemy) { puts "3" }

event.dispatch
```

The output of the above code is:

```ruby
1
2
3
4
```

# Roadmap

Since Seh is developed to be used in game engines, efficiency is an issue.  There's a toy benchmark in 'rake benchmark'.

# Release Notes

* v0.3.0 - new `Event` API, significantly expanded test coverage, documentation, examples, released under the [BSD license](http://opensource.org/licenses/BSD-3-Clause).
* v0.1.0 - an older version of the API that's not backwards-compatible

# License

Seh is released under the [BSD license](http://opensource.org/licenses/BSD-3-Clause).
