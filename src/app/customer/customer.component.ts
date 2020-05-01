import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import { ActivatedRoute, Params } from '@angular/router';
import { LoadingService } from "../loading.service";

@Component({
  selector: 'app-customer',
  templateUrl: './customer.component.html',
  styleUrls: ['./customer.component.css']
})
export class CustomerComponent implements OnInit {

  user;
  username;
  password;
  
  constructor(
    private apiService : ApiService, 
    private router : ActivatedRoute,
    private loadingService: LoadingService
    ) { }

  ngOnInit() {

    // this.apiService.getUsers().subscribe((users : any) => {
    //   //loop through users find the user u want then set the user to the declared variable on top
    //   this.users = users;
    // })

    this.loadingService.loading.next(true);
    this.router.params.subscribe((params: Params) => {
      this.username = params.username;
    })
    this.apiService.getUserInfo(this.username).subscribe((user : any) => {
      this.user = user;
      console.log(this.user);
    })
    this.loadingService.loading.next(false);

  }

}
