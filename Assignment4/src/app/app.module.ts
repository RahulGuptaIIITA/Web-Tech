import { NgModule } from '@angular/core';
import { HttpModule } from '@angular/http';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {NgbModule} from '@ng-bootstrap/ng-bootstrap';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppComponent } from './app.component';
import { PlacesComponent } from './places/places.component';
import { PlacedetailsComponent } from './places/placedetails/placedetails.component';


const ROUTES = [
    {
      path: '',
      pathMatch: 'full',
      component: AppComponent
    },

    {
      path: 'places',
      component: PlacesComponent
    }
];


@NgModule({
  declarations: [
    AppComponent,
    PlacesComponent,
    PlacedetailsComponent
  ],
  
  imports: [
    BrowserModule,
    HttpModule,
    FormsModule,
    BrowserAnimationsModule,
    NgbModule.forRoot(),
    RouterModule.forRoot(ROUTES)
  ],
  
  providers: [],
  
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
