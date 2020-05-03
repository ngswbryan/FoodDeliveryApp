import { Component, OnInit } from '@angular/core';
import { BsModalRef } from 'ngx-bootstrap/modal';
import { ApiService } from "../api.service";

@Component({
  selector: 'app-modal-content',
  templateUrl: './modal-content.component.html',
  styleUrls: ['./modal-content.component.css']
})
export class ModalContentComponent implements OnInit {
  title: string;
  list: any[] = []; //this list is connected to the parent component 
  foodItems = [];

  constructor(
    private bsModalRef: BsModalRef,
    private apiService: ApiService
  ) { }

  ngOnInit() {
    this.apiService.getListOfFoodItem(this.list).subscribe((fooditem: any) => {
      console.log("testing testing food item" + fooditem);
      for (let i = 0; i < fooditem.length; i++) {
        let current = fooditem[i]["list_of_fooditems"];
        let result = current.substring(1, current.length-1);
        let arr = result.split(",");
        this.foodItems.push(arr);
      }
    });
  }
  confirm() {
    // do stuff
    this.close();
  }
  close() {
    this.bsModalRef.hide();
  }

}
