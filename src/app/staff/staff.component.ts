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
  menu = [];
  staff;

  createFoodForm = new FormGroup({
    name: new FormControl(""),
    price: new FormControl(""),
    cuisine_type: new FormControl(""),
    quantity: new FormControl(""),
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
        .subscribe((staff: any) => {
          this.apiService
            .getStaffByUsername(staff[0].uid)
            .subscribe((staffDetails: any) => {
              this.staff = staffDetails;
              this.updateMenu();
              this.loadingService.loading.next(false);
            });
        });
    });
  }

  updateMenu() {
    this.menu = [];
    this.apiService
      .getListOfFoodItem(this.staff[0].rid)
      .subscribe((rest: any) => {
        this.menu = rest;
        console.log(this.menu[0]);
      });
  }

  delete(i) {
    this.loadingService.loading.next(true);
    this.apiService
      .deleteMenuItem(this.menu[i].food_name, this.staff[0].rid)
      .subscribe(() => {
        this.updateMenu();
        this.loadingService.loading.next(false);
      });
  }

  showAdd() {
    this.add = true;
  }

  submitForm() {
    this.loadingService.loading.next(true);
    this.add = false;
    let newFood = {
      name: this.createFoodForm.value.name,
      price: Number(this.createFoodForm.value.price),
      cuisine_type: this.createFoodForm.value.cuisine_type,
      quantity: Number(this.createFoodForm.value.quantity),
      availability: this.createFoodForm.value.availability == "true",
      rid: Number(this.staff[0].rid),
    };
    console.log(newFood);
    this.apiService.addMenuItem(newFood).subscribe(() => {
      this.updateMenu();
      this.loadingService.loading.next(false);
    });
  }

  generateReport() {
    this.showReport = true;
    //generation logic
  }

  addCampaign() {
    this.campaigns.push(this.newCampaign);
  }
}
