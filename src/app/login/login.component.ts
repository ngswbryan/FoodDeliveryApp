import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import { LoadingService } from '../loading.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  users = [];

  constructor(private ApiService: ApiService,
    private loadingService: LoadingService) { }

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.ApiService.getUsers().subscribe((users : any) => {
      this.users = users;
      console.log(users);
    });
    this.loadingService.loading.next(false);
  }

  login(user, password) {
    console.log("ok");
  }

}
