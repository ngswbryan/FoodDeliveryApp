import { Component, OnInit } from '@angular/core';
import { ApiService } from '../api.service';
import { LoadingService } from '../loading.service';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  users = [];

  constructor(private ApiService: ApiService,
    private loadingService: LoadingService,
    public router: Router,
    public toastr: ToastrService) { }

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.ApiService.getUsers().subscribe((users : any) => {
      this.users = users;
    });
    this.loadingService.loading.next(false);
  }

  login(inputuser, inputpassword) {
    this.loadingService.loading.next(true);
    for (let user of this.users) {
      if (user.username === inputuser) {
        if (user.password === inputpassword) {
          if (user.user_role === 'rider') {
            this.router.navigate([`/rider/${user.username}`]);
          } else if (user.user_role === 'staff') {
            this.router.navigate([`/staff/${user.username}`]);
          } else if (user.user_role === 'customer') {
            this.router.navigate([`/customer/${user.username}`]);
          } else {
            this.router.navigate([`/manager/${user.username}`]);
          }
        } else {
          this.toastr.error("Wrong password!");
        }
      } else {
        continue;
      }
    }
    this.toastr.error("No such user");
    this.loadingService.loading.next(true);
  }

}
