import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { ModalModule } from 'ngx-bootstrap/modal';
import { TooltipModule } from 'ngx-bootstrap/tooltip';
import { NgxLoadingModule } from 'ngx-loading';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { ApiService } from './api.service';
import { LoginComponent } from './login/login.component';
import { LoadingComponent } from './loading/loading.component';
import { LoadingService } from './loading.service';

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    LoadingComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    ModalModule.forRoot(),
    TooltipModule.forRoot(),
    NgxLoadingModule.forRoot({})
    
  ],
  providers: [ApiService, LoadingService],
  bootstrap: [AppComponent]
})
export class AppModule { }
