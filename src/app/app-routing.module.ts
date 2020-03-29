import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { RiderComponent } from './rider/rider.component';
import { CustomerComponent } from './customer/customer.component';
import { StaffComponent } from './staff/staff.component';
import { ManagerComponent } from './manager/manager.component';
import { LoginComponent } from './login/login.component';


const routes: Routes = [
  { path: '', component: LoginComponent },
  { path: 'rider/:username', component: RiderComponent },
  { path: 'customer/:username', component: CustomerComponent },
  { path: 'staff/:username', component: StaffComponent },
  { path: 'manager/:username', component: ManagerComponent },];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
