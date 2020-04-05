import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import { ActivatedRoute, Params } from '@angular/router';

@Component({
  selector: 'app-customer',
  templateUrl: './customer.component.html',
  styleUrls: ['./customer.component.css']
})
export class CustomerComponent implements OnInit {

  constructor(private apiService : ApiService, private router : ActivatedRoute) { }

  users = {};

  ngOnInit() {

    this.apiService.getUsers().subscribe((users : any) => {
      //loop through users find the user u want then set the user to the declared variable on top
      this.users = users;
    })

    this.router.params.subscribe((params: Params) => {
      console.log(params.username);
    })

  }

}
