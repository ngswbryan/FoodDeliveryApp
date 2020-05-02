import { Component, OnInit } from "@angular/core";
import { ApiService } from "../api.service";
import { LoadingService } from "../loading.service";
import { FormGroup, FormArray, FormControl, Validators } from "@angular/forms";
import { Router } from "@angular/router";

@Component({
  selector: "app-register",
  templateUrl: "./register.component.html",
  styleUrls: ["./register.component.css"],
})
export class RegisterComponent implements OnInit {
  createUserForm: FormGroup;
  users = [];
  role = "";
  restaurants = [];

  constructor(
    private apiService: ApiService,
    private loadingService: LoadingService,
    public router: Router
  ) {}

  ngOnInit() {
    this.createUserForm = new FormGroup({
      name: new FormControl(""),
      username: new FormControl(""),
      password: new FormControl(""),
      user_role: new FormControl(""),
      rider_type: new FormControl(""),
      restaurant_name: new FormControl(""),
    });
    this.loadingService.loading.next(true);
    this.apiService.getUsers().subscribe((users: any) => {
      this.users = users;
      this.apiService.getRestaurants().subscribe((restaurants: any) => {
        this.restaurants = restaurants;
        this.loadingService.loading.next(false);
      });
    });
  }

  submitForm() {
    if (!this.createUserForm.value.name) {
      window.alert("Please enter your name.");
    } else if (!this.createUserForm.value.username) {
      window.alert("Please enter a valid username");
    } else if (!this.createUserForm.value.password) {
      window.alert("Please enter a password");
    } else if (!this.createUserForm.value.user_role) {
      window.alert("Please select a role");
    } else {
      let duplicateUser = false;
      for (let i = 0; i < this.users.length; i++) {
        if (this.users[i].username === this.createUserForm.value.username) {
          duplicateUser = true;
          break;
        }
      }
      if (duplicateUser) {
        window.alert("Username already taken!");
      } else {
        this.apiService.addUser(this.createUserForm.value).subscribe(() => {
          console.log("user added");
          this.goToLogin();
        });
      }
    }
  }

  onChange(role) {
    this.role = role;
  }

  isRider() {
    if (this.role === "rider") {
      return true;
    } else {
      return false;
    }
  }

  isRestaurant() {
    if (this.role === "staff") {
      return true;
    } else {
      return false;
    }
  }

  goToLogin() {
    this.router.navigate(["/"]);
  }
}
