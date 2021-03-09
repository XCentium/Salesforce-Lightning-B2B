global class PSSelectOptionWrapper{
	global SelectOption selectOption{get;set;}
	global PSSelectOptionWrapper(SelectOption selectOption){
		this.selectOption = selectOption;
	}
}