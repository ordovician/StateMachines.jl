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
end

FSM{State, Event}(state::State) where {State, Event} = FSM(state, Transition{State, Event}[])

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
       fsm.state = fsm.transitions[first(r)].s1 
    end
    fsm.state
end

end # module
