function updateRole(){
	var newRole = this.innerHTML;
	document.getElementById('role').innerHTML = newRole;
	document.getElementById('myrole').setAttribute("value", newRole);
}

function updateState(newState){
	var newState = this.innerHTML;
	document.getElementById('state').innerHTML = newState;
	document.getElementById('mystate').setAttribute("value", newState);
}


window.onload = function(){
	var roles = document.getElementsByClassName('myRole');
	var states = document.getElementsByClassName('myState');
	
	var newRole = [];
	var newState = [];
	for(i = 0; i < roles.length; i++){
		newRole.push(roles[i].innerHTML);
		roles[i].addEventListener('click', updateRole);
	}
	for(i = 0; i < states.length; i++){
		newState.push(states[i].innerHTML);
		states[i].addEventListener('click', updateState);
	}
}