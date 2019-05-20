pragma solidity >=0.4.21 <0.6.0;

import "./RestrictedToOwner.sol";

contract CircuitBreaker is RestrictedToOwner{
  enum CircuitBreakerState {Halted, NoEmergency, RedAlert}

  CircuitBreakerState private circuitBreakerState = CircuitBreakerState.NoEmergency;

  modifier notInEmergency(){if (circuitBreakerState == CircuitBreakerState.NoEmergency) _;}
  modifier inEmergency(){if (circuitBreakerState != CircuitBreakerState.NoEmergency) _;}
  modifier inRedAlert(){if (circuitBreakerState == CircuitBreakerState.RedAlert) _;}

  //events
  event CircuitBreakerStopped();
  event CircuitBreakerInRedAlert();
  event CircuitBreakerEmergencyEnded();

  function setCirctuitBreakerToStopped() public restrictedToOwner{
    circuitBreakerState = CircuitBreakerState.Halted;
    emit CircuitBreakerStopped();
  }

  function setCirctuitBreakerToRedAlert() public notInEmergency restrictedToOwner{
    circuitBreakerState = CircuitBreakerState.RedAlert;
    emit CircuitBreakerInRedAlert();
  }

  function setCircuitBreakerEmergencyFinished() public inEmergency restrictedToOwner{
    circuitBreakerState = CircuitBreakerState.NoEmergency;
    emit CircuitBreakerEmergencyEnded();
  }

}