import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { LoadingService } from "../loading.service";
import { BsModalService, BsModalRef } from 'ngx-bootstrap/modal';
import { ModalContentComponent } from '../modal-content/modal-content.component';
import { ApiService } from "../api.service";
import { DataService } from "../data.service";


@Component({
  selector: 'app-customer',
  templateUrl: './customer.component.html',
  styleUrls: ['./customer.component.css']
})

export class CustomerComponent implements OnInit {

  hasOrdered: boolean;  
  bsModalRef: BsModalRef;
  username;
  user;
  uid;  
  pastDeliveries = [];
  pastReviews = [];
  restaurants = [];
  foodItems = [];
  confirmedList=[]; 
  
  
  constructor(
    private router : ActivatedRoute,
    private loadingService: LoadingService,
    private modalService: BsModalService,
    private apiService: ApiService,
    private dataService: DataService
    ) { }

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.dataService.currentMessage.subscribe(hasOrdered => this.hasOrdered = hasOrdered);
    this.dataService.currentList.subscribe(confirmedList => this.confirmedList = confirmedList);
    this.router.params.subscribe((params: Params) => {
      this.username = params.username;
        this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any)=> {
          console.log(test[0].uid);
          console.log(test);
          this.uid = test[0].uid; 

          this.apiService.getPastDeliveryRating(this.uid).subscribe((delivery: any) => {

            for (let i = 0; i < delivery.length; i++) {
              let current = delivery[i]["past_delivery_ratings"];
              let result = current.substring(1, current.length-1);
              let arr = result.split(",");
              this.pastDeliveries.push(arr);
            }
            this.loadingService.loading.next(false);
          });

          this.apiService.getPastFoodReviews(this.uid).subscribe((review: any) => {
            
            for (let i = 0; i < review.length; i++) {
              let current = review[i]["past_food_reviews"];
              let result = current.substring(1, current.length-1);
              let arr = result.split(",");
              this.pastReviews.push(arr);
            }
            this.loadingService.loading.next(false);
          });


          this.apiService.getRestaurants().subscribe((restaurant: any) => {
            
            for (let i = 0; i < restaurant.length; i++) {
              let current = restaurant[i]["list_of_restaurant"];
              let result = current.substring(1, current.length-1);
              let arr = result.split(",");
              this.restaurants.push(arr);
            }
            this.loadingService.loading.next(false);
          });
          
  
        })

    })
    
  }

  showYourModal(i) {
    const rid = i+1;
    const min = this.restaurants[i][2];
    var initialState = {
      list: [
        rid
      ],
      orderList: [
      ],
      minOrder: [
        min
      ],
      foodItems: [
      ],
      title:'List of food items'
    };

    this.bsModalRef = this.modalService.show( ModalContentComponent, {initialState});
    this.bsModalRef.content.closeBtnName = 'Close';
  }

}

