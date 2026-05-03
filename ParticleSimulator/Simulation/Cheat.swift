shared variables
    mutex : semaphore = 1
    wall  : semaphore = 0
    count : integer = 0

procedure arriveAndWait() begin
    P(mutex)
    count := count + 1

    if count < N then
        V(mutex)
        P(wall)
    else
        // last process to arrive
        V(wall)
    end if

    count := count - 1

    if count > 0 then
        V(wall)
    else
        // last process to leave
        V(mutex)
    end if
end


