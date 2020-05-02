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

  username;
  
  constructor(
    private apiService : ApiService, 
    private router : ActivatedRoute,
    private loadingService: LoadingService
    ) { }

  ngOnInit() {

    this.loadingService.loading.next(true);
    this.router.params.subscribe((params: Params) => {
      this.username = params.username;
    })
    this.loadingService.loading.next(false);

  }

  openMenu() {
    console.log("buttons works");
  }

}
