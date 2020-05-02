import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Params } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";
import { FormGroup, FormControl } from "@angular/forms";

@Component({
  selector: "app-staff",
  templateUrl: "./staff.component.html",
  styleUrls: ["./staff.component.css"],
})
export class StaffComponent implements OnInit {
  username;
  newCampaign;
  add = false;
  showReport = false;
  campaigns = ["campaign1", "campaign2", "campaign3", "campaign4"];
  menu = [
    {
      name: "burger",
      id: 1,
      cuisine_type: "western",
      rating: 100,
      daily_limit: 20,
      availability: "available",
    },
    {
      name: "pizza",
      id: 2,
      cuisine_type: "western",
      rating: 100,
      daily_limit: 20,
      availability: "available",
    },
    {
      name: "fries",
      id: 3,
      cuisine_type: "western",
      rating: 100,
      daily_limit: 20,
      availability: "available",
    },
  ];

  createFoodForm = new FormGroup({
    name: new FormControl(""),
    cuisine_type: new FormControl(""),
    daily_limit: new FormControl(""),
    availability: new FormControl(""),
  });

  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService
  ) {}

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.route.params.subscribe((params: Params) => {
      this.username = params.username;
      this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any) => {
          console.log(test);
        });
    });
    this.loadingService.loading.next(false);
  }

  delete(i) {
    //delete //then get menu items again;
  }

  showAdd() {
    this.add = true;
  }

  submitForm() {
    this.add = false;
    let newFood = {
      name: this.createFoodForm.value.name,
      id: 4,
      cuisine_type: this.createFoodForm.value.cuisine_type,
      rating: 100,
      daily_limit: this.createFoodForm.value.daily_limit,
      availability: this.createFoodForm.value.availability,
    };
    this.menu.push(newFood);
  }

  generateReport() {
    this.showReport = true;
    //generation logic
  }

  addCampaign() {
    this.campaigns.push(this.newCampaign);
  }
}
