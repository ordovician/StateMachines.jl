module StateMachines
import  Base: isless
export  FSM, Transition,
        add_transition!, optimize!, fire!

struct Transition{State, Event}
    s0::State
    event::Event
    s1::State
end

Transition(state::State, event::Event) where {State, Event} = Transition(state, event, state)

mutable struct FSM{State, Event}
    state::State
    transitions::Array{Transition{State, Event}}
    exit_callbacks::Dict{State, Function}
    transition_callbacks::Dict{Int64}   # Index same as transitions.
    enter_callbacks::Dict{State, Function}
end

function FSM{State, Event}(state::State) where {State, Event}
    FSM(state, 
        Transition{State, Event}[], 
        Dict{State, Function}(),
        Dict{Int64, Function}(), 
        Dict{State, Function}())
end

function add_transition!(fsm::FSM{State, Event}, s0::State, event::Event, s1::State) where {State, Event}
    push!(fsm.transitions, Transition(s0, event, s1))
end

function optimize!(fsm::FSM)
    sort!(fsm.transitions)
end

function isless(t1::Transition, t2::Transition)
    if t1.s0 == t2.s0
        if t1.event == t2.event
            false
            # isless(t1.s1, t2.s1)
        else
            isless(t1.event, t2.event)
        end
    else
        isless(t1.s0, t2.s0)
    end
end

function fire!(fsm::FSM{State, Event}, event::Event) where {State, Event}
    r = searchsorted(fsm.transitions, Transition(fsm.state, event))
    if !isempty(r)
        i = first(r)
        prev = fsm.state
        transition = fsm.transitions[i]
        fsm.state = transition.s1
        
        # chech if there are any registered callbaks for when exiting state s0
        if haskey(fsm.exit_callbacks, transition.s0)
            fsm.exit_callbacks[transition.s0](transition)
        end
        
        # check if there are callbacks registered for a transition from
        # state s0 to s1 with event.
        if haskey(fsm.transition_callbacks, i)
            fsm.transition_callbacks[i](transition)
        end
        
        # any callbacks for when entering state s1?
        if haskey(fsm.enter_callbacks, transition.s1)
            fsm.enter_callbacks[transition.s1](transition)
        end
    end
    fsm.state
end

function on_enter!(f::Function, fsm::FSM{State, Event}, s1::State) where {State, Event}
    fsm.on_enter[s1] = f
end

function on_transition!(f::Function, fsm::FSM{State, Event}, s0::State, event::Event) where {State, Event}
    r = searchsorted(fsm.transitions, Transition(fsm.state, event))
    if !isempty(r)
        i = first(r)
    end
end

function on_exit!(f::Function, fsm::FSM{State, Event}, s0::State) where {State, Event}
    fsm.exit_callbacks[s0] = f
end

end # module
