function insertCat(){
	var insert_name = document.getElementById('new_name').value;
	var insert_des =  document.getElementById('new_des').value;

	document.getElementById('insert_name').value = insert_name;
	document.getElementById('insert_des').value = insert_des;
}

function updateCat(){
	var update_name = this.parentElement.parentElement.getElementsByClassName('update_names')[0].value;
	var update_des = this.parentElement.parentElement.getElementsByClassName('update_deses')[0].value;
	
	this.parentElement.getElementsByClassName('update_name')[0].value = update_name;
	this.parentElement.getElementsByClassName('update_des')[0].value = update_des;
}

function deleteCat(){
	var delete_name = this.parentElement.parentElement.getElementsByClassName('update_names')[0].value;
	
	this.parentElement.getElementsByClassName('delete_name')[0].value = delete_name;
}

window.onload = function(){
	document.getElementById('insert').addEventListener('click', insertCat);
	var updateButton = document.getElementsByClassName('update');
	var deleteButton = document.getElementsByClassName('delete');
		
	for(i = 0; i < updateButton.length; i++){
		updateButton[i].addEventListener('click', updateCat);
		deleteButton[i].addEventListener('click', deleteCat);
	}
}